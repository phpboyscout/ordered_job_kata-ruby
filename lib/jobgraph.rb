require 'rgl/adjacency'
require 'rgl/topsort'

class JobGraph
  def initialize
    @graph = RGL::DirectedAdjacencyGraph.new
  end

  def add_job(from, to)
    raise ArgumentError.new(%Q{job "#{to}" can't depend on itself}) if to == from
    @graph.add_edge(from, to)
  end

  def sequenced
    raise ArgumentError.new("The job graph cannot contain cyclic dependencies") unless @graph.acyclic?
    @graph.topsort_iterator.to_a.reject { |job| job == "" }
  end
end
