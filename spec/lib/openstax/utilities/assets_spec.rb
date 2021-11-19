require 'rails_helper'
require 'vcr_helper'

RSpec.describe OpenStax::Utilities::Assets, vcr: VCR_OPTS do
  before { RequestStore.store[:assets_manifest] = nil }

  it 'defaults to name.js when manifest is missing' do
    expect_any_instance_of(Faraday::Connection).to receive(:get).and_return(
      OpenStruct.new success?: false
    )
    expect(described_class.tags_for(:foo)).to include "src='http://localhost:8000/dist/foo.js'"
  end

  it 'reads asset url from manifest' do
    expect_any_instance_of(Faraday::Connection).to receive(:get).and_return(
      OpenStruct.new(
        success?: true,
        body: { entrypoints: { foo: { js: [ 'foo-732c56c32ff399b62.min.bar' ] } } }.to_json
      )
    )
    expect(described_class.tags_for(:foo)).to include(
      "src='http://localhost:8000/dist/foo-732c56c32ff399b62.min.bar'"
    )
  end

  context 'loading remote manifest' do
    before do
      @config = OpenStax::Utilities.configuration
      @previous_assets_url = @config.assets_url
      @config.assets_url = 'https://tutor-dev.openstax.org/assets'
    end
    after  { @config.assets_url = @previous_assets_url }

    it 'uses remote json' do
      expect(described_class.manifest).to be_kind_of described_class::Manifest
      expect(described_class.tags_for(:tutor)).to(
        eq "<script type='text/javascript' src='https://tutor-dev.openstax.org/assets/tutor-b920eb0be760a7c440bf.min.js' crossorigin='anonymous' async></script>"
      )
    end
  end
end
