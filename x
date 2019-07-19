I am a keyboard person and try to use the keyboard as much as I can. WHen I want
to copy passwords to be used elsewhere from my browser, I usually open the
developer tools console, inspect element and click on the password input box and
then run the following code.

```javascript
copy($0.value)
```

Chrome sets `$0` to refer to the currently selected DOM element and `$0.value`
will give us the value of the password field and sending it to the `copy`
function copies this text to the OS clipboard.

I have a similar script set up for my terminal, when I want to copy the output
of a command like `rake secret` I run the following command:

```bash
rake secret | xc
echo "Hello" | xc
```

`xc` is aliases to the following in my bashrc

```bash
alias xc='tee /dev/tty | xclip -selection clipboard'
```

This command prints the output to the terminal and copies it to the OS
clipboard.

```bash
$ echo "Hello" | xc
Hello
# Now `Hello` has been copied to the OS clipboard
```

I wanted the same ability in my ruby and elixir REPLs. It was pretty
straightforward to do in ruby. Here is the annotated code:

```ruby
puts 'loading ~/.pryrc ...'

require 'open3'

# copy takes an argument and converts it into a string and copies it to the OS
# clipboard using the `xclip` command line package.
def copy(text)
  # start running the `xclip` command to copy the stdin to the OS primary
  # clipboard. Also pass the stdin and stdout, stderr to the block
  Open3.popen3('xclip', '-selection', 'clipboard') do |stdin, _stdout, _stderr, _wait_thr|
    # convert the input argument to a string and write it to the stdin of the
    # spawned `xclip` process and the close the input stream
    stdin.puts text.to_s
    stdin.close
  end

  # print out an informational message to signal that the argument has been
  # copied to the clipboard.
  puts "copied to clipboard: #{text.to_s[0..10]}..."
end

# e.g. running `copy SecureRandom.uuid` will print the following
# pry(main)> copy SecureRandom.uuid
# copied to clipboard: 14438d5c-62...
# and copies: `14438d5c-62b9-40a1-a324-5d2bd2205990` to the OS clipboard
```

I did the same for Elixir as I use it too:

```elixir
IO.puts("loading ~/.iex.exs")

# open a module called `H` as we can't have functions outside modules
defmodule H do
  # copy function takes the input and converts it into a string before copying
  # it to the OS clipboard.
  def copy(text) do
    # convert input argument to a string
    text = to_s(text)

    # spawn a new xclip process configured to copy the stdin to the OS's primary
    # clipboard
    port = Port.open({:spawn, "xclip -selection clipboard"}, [])
    # send the input text as stdin to the xclip process
    Port.command(port, text)
    # close the port
    Port.close(port)

    # print out an informational message to signal that the text has been copied
    # to the OS's clipboard"
    IO.puts("copied to clipboard: #{String.slice(text, 0, 10)}...")
  end

  # to_s converts an elixir term to a string if it implements the `String.Chars`
  # protocol otherwise it uses `inspect` to convert it into a string.
  defp to_s(text) do
    to_string(text)
  rescue
    _ -> inspect(text)
  end
end
```


```elixir
iex(2)> :crypto.strong_rand_bytes(16) |> Base.encode16 |> H.copy
# copied to clipboard: 347B175C6F...
# it has also copied `347B175C6F397B2808DE7168444ED428` to the OS's clipboard
```

All these utilities (except for the browser's `copy` function) depend on the
`xclip` utility which can be installed on ubuntu using `sudo apt-get install
xclip`. You can emulate the same behaviour on a Mac using the `pbcopy` utility,
you might have to tweak things a little bit, but it should be pretty straightforward.
