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
		
		if parts.length > 1 then # If there is at least one parent
			parents = []
			distr = {parts[1] => line[1].to_f}
			node.add_distr distr

			parts[1].split(',').each do |p|
				parents.push p[1..-1]
			end
			node.set_parents parents
			# This will overwrite the previous detected parents in a node, they should be the same for
			# the same node, so no problem
		else
			node.set_distr line[1].to_f
		end
	end
	nodes.print_all

	# Read the queries
	n = $stdin.readline.to_i
	for i in 1..n
		line = $stdin.readline.chomp
		parts = line.split '|'
		query = parts[0]
		if parts.length == 1 then # If the query consists only of one node (no evidence)
			puts probability_of(query, nodes)
		else
			evidence = parts[1]
			upper = "#{query},#{evidence}"
			puts upper
			puts "Query"
			puts probability_of(upper, nodes)
			puts "Evidence"
			puts probability_of(evidence, nodes)
			puts "Result"
			puts probability_of(upper, nodes) / probability_of(evidence, nodes)

		end
	end
end

# Compute the probability of the given string, looking for intersections or nodes by themselves
def probability_of(query, net)
	parts = query.split ','
	if parts.length == 1 then  # Only one node
		node = net.find(query[1..-1])

		if node.parents.nil? then # If the query's node has no parent
			if query[0] == '+'
				return node.distr
			else
				return 1 - node.distr
			end
		else
			# Total probability
			sum = 0
			node.distr.each do |d, p|
				sum += probability_of(d, net) * p
			end
			if query[0] == '+'
				return sum
			else
				return 1 - sum
			end
		end

	else
		# Chain rule
	end
end


def chain_rule(query, net)
	involved_nodes = query.gsub('+', '')
	involved_nodes.gsub!('-', '')
	involved_nodes = involved_nodes.split(',')
	parents_added = 0
	new_queries = [query]

	parts = query.split ','
	if parts.length > 1 then
		res = 1
		parts.each do |p|
			node = net.find(p[1..-1])
			sign = p[0]
			if node.parents.nil?
				if sign == '+' then
					res *= node.distr
				else
					res *= (1-node.distr)
				end
			else
				# For each parent that is not included yet
				(node.parents - involved_nodes).each do |a|
					involved_nodes.push a
					parents_added += 1
					new_queries *= 2
					for i in 0..(parents_added)-1
						new_queries[i] += ",+#{a}"
						new_queries[(parents_added * 2)-1-i] += ",-#{a}"
					end
				end

				new_queries.each do |q|
					res *= chain_rule(q, net)
				end
			end
		end
		return res
	end

			signs = []

			no_dups = signs.permutation(3).to_a.uniq

end


main