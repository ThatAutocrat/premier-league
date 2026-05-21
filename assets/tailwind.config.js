// tailwind.config.js
const path = require("path")

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/football_tracker_web.ex",
    "../lib/football_tracker_web/**/*.*ex"
  ],
  theme: {
    extend: {}
  },
  plugins: []
}
