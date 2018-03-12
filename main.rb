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

	# This function was done just for debugging purposes
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

	def ancestor(net)
		res = []
		if !@parents.nil?
			res = @parents.clone
			@parents.each do |p|
				if !p.nil?
					new_p = net.find p
					res += new_p.ancestor(net)
				end
			end 
		end
		res
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
	# nodes.print_all

	# Read the queries
	n = $stdin.readline.to_i
	for i in 1..n
		line = $stdin.readline.chomp
		parts = line.split '|'
		query = parts[0]
		if parts.length == 1 then # If the query consists only of one node (no evidence)
			puts probability_of(query, nodes).round(7)
		else
			evidence = parts[1]
			upper = "#{query},#{evidence}"
	
			res = probability_of(upper, nodes) / probability_of(evidence, nodes)
			puts res.round(7)
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
		involved_nodes = query.gsub('+', '')
		involved_nodes.gsub!('-', '')
		involved_nodes = involved_nodes.split(',')
		parents_added = 0
		new_queries = [query]

		parts.each do |p|
			node = net.find(p[1..-1])
			if !node.parents.nil? then
				# For each parent that is not included yet
				if !(node.ancestor(net) - involved_nodes).nil? then
					(node.ancestor(net) - involved_nodes).each do |a|
						involved_nodes.push a
						parents_added += 1
						new_queries *= 2
						for i in 0..(parents_added)-1
							new_queries[i] += ",+#{a}"
							new_queries[(parents_added * 2)-1-i] += ",-#{a}"
						end
					end
				end
			end
		end
		sum = 0
		new_queries.each do |q|
			sum += chain_rule(q, net)
		end

		return sum

	end
end


def chain_rule(query, net)

	parts = query.split ','
	
	involved_nodes = Hash.new
	parts.each do |p|
		involved_nodes.merge!({p[1..-1] => p[0]})
	end
	
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
				# Find the prob in distr with the given nodes
				# and symbols in the query, split or do anything necessary with it
				ordered_query = ""
				node.parents.each do |parent|
					ordered_query += involved_nodes[parent] + parent + ","
				end
				if sign == '+'
					res *= node.distr[ordered_query[0..-2]]
				else
					res *= (1 - node.distr[ordered_query[0..-2]])
				end

			end
		end
		return res
	end

end


main