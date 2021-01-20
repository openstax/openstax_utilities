require 'aws-sdk-autoscaling'

class OpenStax::Utilities::StatusController < ActionController::Base
  before_action :authenticate

  layout 'openstax/utilities/status'

  def index
    @application_name = Rails.application.class.parent_name
    @environment_name = Rails.application.secrets.environment_name

    @statuses = if @environment_name == 'development'
      [ [ 'local', 1, 1, :ok ] ]
    else
      queues = Module.const_defined?(:Delayed) && Delayed.const_defined?(:Worker) ?
        Delayed::Worker.queue_attributes.keys.map(&:to_s) - [ 'migration' ] : []
      asgs = [ 'migration', 'web', 'cron', 'background' ] + queues.map do |queue|
        "background-#{queue}"
      end

      Aws::AutoScaling::Client.new.describe_auto_scaling_groups(
        auto_scaling_group_names: asgs.map do |asg|
          "#{@environment_name}-#{@application_name.downcase}-#{asg}-asg"
        end
      ).auto_scaling_groups.map do |asg|
        name = asg.auto_scaling_group_name.sub(
          "#{@environment_name}-#{@application_name.downcase}-", ''
        ).chomp('-asg')

        status = if asg.desired_capacity == 0
          if [ 'web', 'background', 'cron' ].include?(name)
            :configuration_error
          elsif asg.instances.size > 0
            :shutting_down
          else
            :sleeping
          end
        elsif asg.instances.all? do |instance|
                instance.health_status != 'Healthy' || instance.lifecycle_state != 'InService'
              end
          case name
          when 'web'
            :down
          when 'background', 'cron'
            :impacted
          else
            :offline
          end
        elsif name == 'migration'
          :migrating
        elsif asg.max_size > 1 && asg.desired_capacity == asg.max_size
          :at_capacity
        elsif asg.instances.size < asg.desired_capacity
          :scaling_up
        elsif asg.instances.size > asg.desired_capacity
          :scaling_down
        else
          :ok
        end

        [ name, asg.instances.size, asg.max_size, status ]
      end.sort_by do |name, _, _, _|
        case name
        when 'migration'
          '0'
        when 'web'
          '1'
        when 'cron'
          '2'
        else
          "3#{name}"
        end
      end
    end
  end

  protected

  def authenticate
    instance_exec &OpenStax::Utilities.configuration.status_authenticate
  end
end
