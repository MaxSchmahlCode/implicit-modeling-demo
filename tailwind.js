tailwind = window.tailwind || {};
tailwind.config = {
  theme: {
    extend: {
      colors: {
        accent: '#e60026'
      },
      keyframes: {
        fade: {
          "0%": { opacity: 0, transform: "translateY(8px)" },
          "100%": { opacity: 1, transform: "translateY(0)" },
        }
      },
      animation: {
        fade: "fade 0.6s ease-out forwards"
      }
    }
  }
}