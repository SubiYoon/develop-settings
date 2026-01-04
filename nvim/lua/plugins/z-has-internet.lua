-- 인터넷 연결 상태 알림 (VeryLazy로 마지막에 로드)
return {
  name = "internet-check",
  dir = vim.fn.stdpath("config"),
  lazy = false,
  priority = 1, -- 가장 낮은 우선순위 (마지막 로드)
  config = function()
    vim.defer_fn(function()
      local utils = require("utils.commonUtils")
      local has_net = utils.has_internet()
      if has_net then
        vim.notify("🌐 온라인 모드: 인터넷 연결됨", vim.log.levels.INFO)
      else
        vim.notify("⚠️ 오프라인 모드: 인터넷 연결 실패", vim.log.levels.WARN)
      end
    end, 100)
  end,
}
