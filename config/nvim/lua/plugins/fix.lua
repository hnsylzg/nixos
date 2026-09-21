return {
	{
		"catppuccin/nvim",
		opts = function(_, opts)
			-- catppuccin ≥1.7.0 已移除 groups.integrations.bufferline 模块
			-- （bufferline.nvim v4.9+ 自带 catppuccin 支持），直接 require 会抛 module not found。
			-- 故仅在模块仍存在时打补丁，避免配置加载失败。
			local ok, module = pcall(require, "catppuccin.groups.integrations.bufferline")
			if ok and module and module.get_theme then
				module.get = module.get_theme
			end
			return opts
		end,
	},
}
