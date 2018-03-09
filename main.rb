class Network
	def initialize
		@net = []
	end

	def push n
		@net.push n
		self
	end

	def find name_
		@net.find {|node| node.name_ == name_}
	end

	def print_all
		@net.each do |n|
			print n.inspect
			puts ''
		end 
	end
end

class Node
	def initialize(name_)
		@name = name_
		@parents = nil
		@distr = Hash.new
	end

	def set_parents(parents)
		@parents = parents
	end

	def set_distr(distr)
		@distr = distr
	end

	def add_distr(distr)
		@distr.merge!(distr)
	end

	def name_
		@name
	end

	def parents
		@parents
	end

	def distr
		@distr
	end
end

def main
	# Read the nodes and initialize each of them
	nodes_in = $stdin.readline.chomp
	nodes_in = nodes_in.split ','
	nodes = Network.new

	nodes_in.each do |n|
		nodes.push Node.new n
	end

	# Read the probabilities, the tables
	n = $stdin.readline.to_i
	for i in 1..n
		line = $stdin.readline.chomp.split '=' # Now the value of the prob is line[1]
		parts = line[0].split '|'
		node = nodes.find(parts[0][1..-1])
		# This will overwrite the previous detected parents in a node, they should be the same for
		# the same node, so no problem
		if parts.length > 1 then # If there is at least one parent
			parents = []
			distr = {parts[1] => line[1].to_f}
			node.add_distr distr

			parts[1].split(',').each do |p|
				parents.push p[1..-1]
			end
			node.set_parents parents

		else
			node.set_distr line[1].to_f
		end
	end

	# Read the queries
	n = $stdin.readline.to_i
	for i in 1..n
		line = $stdin.readline.chomp
		parts = line.split '|'
		query = parts[0]
		if parts.length == 1 then # If the query consists only of one node (no evidence)
			node = nodes.find(query[1..-1])
			if node.parents.nil? then # If the query's node has no parent
				if query[0] == '+'
					puts node.distr
				else
					puts 1 - node.distr
				end
			else

			# total probability

			end
		else
			evidence = parts[1]

			# enumeration algorithm

		end
	end

	nodes.print_all
end

main