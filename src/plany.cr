require "commander"
require "./main"
require "./play"

cli = Commander::Command.new do |cmd|
  cmd.use  = "plany"
  cmd.long = "Manage your calendar in YAML."

  cmd.run do |options, arguments|
    main()
  end

  cmd.commands.add do |cmd|
    cmd.use   = "play"
    cmd.short = "Play with date specs."
    cmd.long  = cmd.short

    cmd.flags.add do |flag|
      flag.name        = "from"
      flag.short       = "-f"
      flag.long        = "--from"
      flag.default     = "today"
      flag.description = "Start date [Y/M/D]."
    end

    cmd.flags.add do |flag|
      flag.name        = "years"
      flag.short       = "-y"
      flag.long        = "--years"
      flag.default     = 100
      flag.description = "How many years ahead to consider."
    end

    cmd.run do |options, arguments|
      play(options.string["from"], options.int["years"])
    end
  end
end

Commander.run(cli, ARGV)
