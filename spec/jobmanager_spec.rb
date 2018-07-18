require_relative '../lib/jobmanager'

RSpec.describe JobManager do

  context "when supplied and empty string" do
    it 'should resolve to an empty sequence' do
      manager = JobManager.new("")
      expect(manager.sequence).to eq [ ]
    end
  end

  context "when supplied a single job definition" do
    it 'should resolve to a sequence containing a single job' do
      manager = JobManager.new("a => ")
      expect(manager.sequence).to eq %w[ a ]
    end
  end

  context "when supplied a definitions with 3 jobs and no dependencies" do
    it 'should resolve to a sequence containing 3 jobs' do
      manager = JobManager.new(-%{
          a =>
          b =>
          c =>
        })
      expect(manager.sequence).to match_array([ "a", "b", "c" ])
    end
  end

  context "when supplied a definitions with 3 jobs and one dependency" do
    it 'should resolve to a sequence containing 3 jobs in dependency order' do
      manager = JobManager.new(-%{
          a =>
          b => c
          c =>
        })
      expect(manager.sequence).to match_array([ "a", "b", "c" ])
      expect(manager.sequence).to order_element("c").before("b")
    end
  end


  context "when supplied with multiple definitions and valid dependencies" do
    it 'should resolve to a valid sequence containing 3 jobs in dependency order' do
      manager = JobManager.new(-%{
          a =>
          b => c
          c => f
          d => a
          e => b
          f =>
        })
      expect(manager.sequence).to match_array([ "a", "b", "c", "d", "e", "f" ])
      expect(manager.sequence).to order_element("f").before("c")
      expect(manager.sequence).to order_element("c").before("b")
      expect(manager.sequence).to order_element("b").before("e")
      expect(manager.sequence).to order_element("a").before("d")
    end
  end


  context "when supplied with multiples jobs containing at least one self reference" do
    it 'raises and "ArgumentError" preventing self reference' do
      manager = JobManager.new(-%{
          a =>
          b =>
          c => c
        })
      expect { manager.sequence }.to raise_error(ArgumentError, %Q{job "c" can't depend on itself})
    end
  end

  context "when supplied with multiples jobs containing at least one cyclic reference" do
    it 'raises and "ArgumentError" preventing self reference' do
      manager = JobManager.new(-%{
          a =>
          b => c
          c => f
          d => a
          e =>
          f => b
        })
      expect { manager.sequence }.to raise_error(ArgumentError, %Q{The job graph cannot contain cyclic dependencies})
    end
  end

end