title: Brute force
date: 2013-02-19
tags:
- brute-force
- thinking
- solving
---

I am planning to participate in the Google Code Jam this year.
And I have been working on the [practice problems](https://code.google.com/codejam/contests.html). 
It's been fun, It's a great feeling when you are able to solve a challenging
problem after spending time on it.

My strategy for solving problems is simple: First I try the brute force
approach, Once I have a solution, I start thinking of a more efficient way to do it. I have since realized that spending some time thinking  about the problem before butting your head against it is way more helpful. When I reached the [Minimum Scalar Product](https://code.google.com/codejam/contest/32016/dashboard) problem. 

> You are given two vectors v1=(x1,x2,...,xn) and v2=(y1,y2,...,yn). The 
> scalar product of these vectors is a single number, calculated as x1y1+x2y2+...+xnyn.

> Suppose you are allowed to permute the coordinates of each vector as you wish.
> Choose two permutations such that the scalar product of your two new vectors is 
> the smallest possible, and output that minimum scalar product.


I thought for a moment and came up with the idea that I needed all possible combinations
of the first vector with a constant ordered second vector. This algorithm had an order
of O(n!). I just jumped into coding and started solving it. Here is
the ugly mess of code I came up with: 

~~~ruby
    class MinimumScalarProduct
      #naive solution O(n!)
      def self.distribute(x, y)
        #puts "DISTRIBUTING: #{x.length}, #{y.length}"
        if x.length == 1
          return [
            [ [x[0],y[0]] ],
          ]
        end
        if x.length == 2
          #puts "TIME TO GO HOME"
          return [
            [ [x[0],y[0]],  [x[1],y[1]]],
            [ [x[1],y[0]],  [x[0],y[1]]],
          ]
        end


        cumulative_dist = []
        #puts "LEN: #{x.length-1}"
        for i in (0..x.length-1)
          #puts "LETS BREAK IT DOWN #{i}"
          xi = x[i]
          yi = y.first
          newx = x.clone
          newx.delete_at(i)
          newy = y.clone
          newy.delete_at(0)
          dist = distribute(newx, newy)
          dist.each do|d|
            d.unshift([xi,yi])
          end
          cumulative_dist += dist
        end
        return cumulative_dist
      end

      def self.smallest_vector(x,y)
        dist = distribute(x,y)

        #dist.each do |d|
          #puts d.map{|a| "#{a[0]}*#{a[1]}"}.join(" + ")
        #end
        #puts '=================================================='
        #return

        dist =  dist.map do |d|
          d.map{|a| a[0]*a[1]}.inject{|memo, el| memo + el}
        end
        #puts dist.join(";")
        dist.sort.first
      end
    end

    lines = File.readlines(ARGV.first).map(&:chomp)
    no_of_cases = lines.shift.to_i
    for i in (0..no_of_cases-1)
      begin
        n = lines.shift
        xa = lines.shift.strip.split(' ').map{|x| x.to_i} 
        ya = lines.shift.strip.split(' ').map{|x| x.to_i} 
        #MinimumScalarProduct.smallest_vector(xa, ya)
        puts "Case ##{i+1}: #{MinimumScalarProduct.smallest_vector(xa, ya)}"
      rescue StandardError => ex
        STDERR.puts "At i: #{i}"
        STDERR.puts "n:#{n}, xa: #{xa.inspect}, ya: #{ya.inspect}"
        STDERR.puts ex
        STDERR.puts ex.backtrace
        exit
      end
    end
~~~

[Here is an example test file](https://substancehq.s3.amazonaws.com/static_asset/512393734c01e92c45000b78/A-small-practice.in.txt) 
if you want to try it.

Then, I started actually thinking about the problem. After a few minutes it
became clear to me that all I had to do, to get a minimum product, was order the 
two vectors in opposing orders of magnitude. And with this
understanding I could solve it much more easily and with an algorithm with an order of O(nlogn).

~~~ruby
    lines = File.readlines(ARGV.first || 'A-small-practice.in').map{|x| x.chomp}

    t = lines.shift.to_i

    (0..t-1).each do |i|
      lines.shift
      xa = lines.shift.split(' ').map{|x| x.to_i}.sort #O(n log(n))
      ya = lines.shift.split(' ').map{|x| x.to_i}.sort.reverse #O(n log(n))
      min =  xa.zip(ya).map{|x|  x[0] * x[1]}.inject{|memo, x| memo + x} #O(n)
      puts "Case ##{i+1}: #{min}"
    end
~~~

In the past I have used brute force to solve problems where the time didn't
matter (I could always move it to a background process if the time mattered),
but it's a nice feeling to be able to be able to solve problems by simply
thinking. Sometimes we(software developers) are so addicted to the quick
feedback cycle of coding that we fail to spend time thinking of the problem/solution.
