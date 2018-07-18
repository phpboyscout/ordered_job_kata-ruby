require 'jobgraph'
require 'job'

class JobManager
  attr_accessor :definition

  def initialize(definition)
    @definition = definition
  end

  def sequence
    graph = JobGraph.new
    Job.new(@definition).add_to(graph)
    graph.sequenced
  end
end
