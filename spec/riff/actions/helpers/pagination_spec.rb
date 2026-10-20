# frozen_string_literal: true

RSpec.describe(Riff::Actions::Helpers::Pagination) do
  def offset_limit(params, paginate: true, per_page: 20)
    described_class.new(params, { paginate: paginate, per_page: per_page }).offset_limit
  end

  it "uses the default page size without params" do
    expect(offset_limit({})).to eq([nil, 20])
  end

  it "reads the page size from _limit" do
    expect(offset_limit({ _page: "2", _limit: "5" })).to eq([5, 5])
  end

  it "caps _limit at max_per_page" do
    expect(offset_limit({ _limit: (Riff::Conf.max_per_page + 1).to_s }).last).to eq(Riff::Conf.max_per_page)
  end

  it "refuses _per_page out loud" do
    expect { offset_limit({ _per_page: "5" }) }.to raise_error(Riff::Exceptions::InvalidParameters)
  end

  it "refuses _limit where the action does not paginate" do
    expect { offset_limit({ _limit: "5" }, paginate: false) }.to raise_error(Riff::Exceptions::InvalidParameters)
  end

  it "refuses a non-numeric _limit" do
    expect { offset_limit({ _limit: "abc" }) }.to raise_error(Riff::Exceptions::InvalidParameters)
  end
end
