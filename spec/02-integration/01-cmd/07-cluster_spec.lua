local helpers = require "spec.helpers"

describe("kong cluster", function()
  before_each(function()
    helpers.kill_all()
  end)
  teardown(function()
    helpers.kill_all()
    helpers.clean_prefix()
  end)


  it("cluster help", function()
    local _, stderr = helpers.kong_exec "cluster --help"
    assert.not_equal("", stderr)
  end)
  it("generates a key", function()
    local _, stderr, stdout = assert(helpers.kong_exec("cluster keygen"))
    assert.equal("", stderr)
    assert.equal(26, stdout:len()) -- 24 + \r\n
  end)
  it("shows members", function()
    assert(helpers.kong_exec("start --conf "..helpers.test_conf_path))
    local _, _, stdout = assert(helpers.kong_exec("cluster members --conf "..helpers.test_conf_path))
    assert.matches("alive", stdout)
  end)
  it("shows rechability", function()
    assert(helpers.kong_exec("start --conf "..helpers.test_conf_path))
    local _, _, stdout = assert(helpers.kong_exec("cluster reachability --conf "..helpers.test_conf_path))
    assert.matches("Successfully contacted all live nodes", stdout)
  end)
  it("force-leaves a node", function()
    assert(helpers.kong_exec("start --conf "..helpers.test_conf_path))
    local _, _, stdout = assert(helpers.kong_exec("cluster force-leave 127.0.0.1 --conf "..helpers.test_conf_path))
    assert.matches("left node 127.0.0.1", stdout, nil, true)
  end)

  describe("errors", function()
    it("fails to show members when Kong is not running", function()
      local ok, stderr = helpers.kong_exec("cluster members --conf "..helpers.test_conf_path)
      assert.False(ok)
      assert.matches("Error connecting to Serf agent", stderr)
    end)
    it("fails to show reachability when Kong is not running", function()
      local ok, stderr = helpers.kong_exec("cluster reachability --conf "..helpers.test_conf_path)
      assert.False(ok)
      assert.matches("Error connecting to Serf agent", stderr)
    end)
    it("fails to force-leave when a node is not specified", function()
      local ok, stderr = helpers.kong_exec("cluster force-leave --conf "..helpers.test_conf_path)
      assert.False(ok)
      assert.matches("must specify the name of the node to leave", stderr)
    end)
  end)
end)
