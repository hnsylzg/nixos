-- 关闭 LazyVim 启动时的 "What's new?"（NEWS.md）弹窗。
-- 原因：本配置的 ~/.config/nvim 由 home-manager 以只读符号链接部署到 /nix/store，
-- LazyVim 无法把"已读"标记写回 lazyvim.json，导致更新日志每次启动都重新弹出。
-- 声明式只读配置下，直接关掉是唯一干净的做法。
return {
	{
		"LazyVim/LazyVim",
		opts = {
			news = {
				lazyvim = false, -- 关闭 LazyVim 自身 NEWS.md 弹窗
				neovim = false, -- 关闭 Neovim news.txt 弹窗
			},
		},
	},
}
