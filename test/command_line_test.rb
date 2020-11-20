# we mostly unit test with a Traject::Indexer itself and lower-level, but
# we need at least some basic top-level integration actually command line tests,
# this is a start, we can add more.
#
# Should we be testing Traject::CommandLine as an object instead of/in addition to
# actually testing shell-out to command line call? Maybe.

require 'test_helper'

describe "Shell out to command line" do
  # just encapsuluate using the minitest capture helper, but also
  # getting and returning exit code
  #
  #     out, err, result = execute_with_args("-c configuration")
  def execute_with_args(args)
    out, err = capture_subprocess_io do
      system("./bin/traject #{args}")
    end

    return out, err, $?
  end


  it "can dispaly version" do
    out, err, result = execute_with_args("-v")
    assert_equal err, "traject version #{Traject::VERSION}\n"
    assert result.success?
  end

  it "can display help text" do
    out, err, result = execute_with_args("-h")

    assert err.start_with?("traject [options] -c configuration.rb [-c config2.rb] file.mrc")
    assert result.success?
  end

  it "handles bad argument" do
    out, err, result = execute_with_args("-no-such-arg")

    refute result.success?

    assert err.start_with?("Error: Unknown options -no-such-arg\nExiting...\n")
  end

  it "does basic dry run" do
    out, err, result = execute_with_args("--debug-mode -s one=two -s three=four -c test/test_support/demo_config.rb test/test_support/emptyish_record.marc")

    assert result.success?
    assert_includes err, "executing with: `--debug-mode -s one=two -s three=four"
    assert_match /bib_1000165 +author_sort +Collection la/, out
  end
end
