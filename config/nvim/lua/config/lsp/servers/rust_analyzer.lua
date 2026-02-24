return {
  settings = {
    ["rust-analyzer"] = {
      check = {
        enable = true,
        command = "clippy",
        features = "all",
      },
    },
  },
}
