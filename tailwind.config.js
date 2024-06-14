const { withMaterialColors } = require('tailwind-material-colors')

config = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,html}',
  ],
  theme: {
    extend: {
      animation: {
        'slide-in-up': 'slide-in-up 0.3s ease-out',
        'slide-out-down': 'slide-out-down 0.3s ease-out'
      },
      keyframes: {
        'slide-in-up': {
          '0%': { transform: 'translateY(100%)', opacity: 0 },
          '100%': { transform: 'translateY(0)', opacity: 1 },
        },
        'slide-out-down': {
          '0%': { transform: 'translateY(0)', opacity: 1 },
          '100%': { transform: 'translateY(100%)', opacity: 0 },
        },
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
  ]
}

module.exports = withMaterialColors(config, {
  // Your base colors as HEX values. 'primary' is required.
  primary: '#3b82f6',
  // secondary and/or tertiary are optional, if not set they will be derived from the primary color.
  // secondary: '#ffff00',
  // tertiary: '#0000ff',
}, {
  /* one of 'content', 'expressive', 'fidelity', 'monochrome', 'neutral', 'tonalSpot' or 'vibrant' */
  scheme: 'content',
  // contrast is optional and ranges from -1 (less contrast) to 1 (more contrast).
  contrast: 0,
  extend: true
})
