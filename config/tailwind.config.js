const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
  content: [
    "./app/views/**/*.html.erb",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ["\"Plus Jakarta Sans\"", ...defaultTheme.fontFamily.sans],
        display: ["\"Fraunces\"", ...defaultTheme.fontFamily.serif],
      },
      colors: {
        ink: {
          50: "#f4f7f5",
          100: "#e6ece8",
          200: "#c9d5cd",
          300: "#a3b5aa",
          400: "#7a9283",
          500: "#5c7565",
          600: "#475c50",
          700: "#3a4a41",
          800: "#313e37",
          900: "#2a342f",
          950: "#151b18",
        },
        accent: {
          50: "#eef9f6",
          100: "#d5f1e9",
          200: "#aee3d4",
          300: "#7ecdb8",
          400: "#4fb39a",
          500: "#359780",
          600: "#287968",
          700: "#236154",
          800: "#1f4e45",
          900: "#1c413a",
        },
        sand: {
          50: "#fbf8f2",
          100: "#f4eee0",
          200: "#e8d9bc",
        },
      },
      boxShadow: {
        soft: "0 1px 2px rgba(21, 27, 24, 0.04), 0 8px 24px rgba(21, 27, 24, 0.06)",
        focus: "0 0 0 2px #fff, 0 0 0 4px #287968",
      },
      backgroundImage: {
        mesh: "radial-gradient(1200px 600px at 10% -10%, rgba(78, 205, 184, 0.18), transparent 55%), radial-gradient(900px 500px at 100% 0%, rgba(232, 217, 188, 0.45), transparent 50%), linear-gradient(180deg, #f4f7f5 0%, #eef3f0 100%)",
      },
    },
  },
  plugins: [require("@tailwindcss/forms")],
};
