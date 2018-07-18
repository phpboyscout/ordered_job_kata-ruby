class Job
  attr_accessor :job_definition

  def initialize(job_definition)
    @job_definition = job_definition
  end

  def add_to(graph)
    dependencies.each do |to, from|
      graph.add_job(from, to)
    end
  end

  private

  def dependencies
    @job_definition.gsub(/\n*^\s*$\n*/, '').split("\n").map { |line|
      match = /(\w) => *(\w?)/.match(line)
      match[1..2]
    }
  end
end