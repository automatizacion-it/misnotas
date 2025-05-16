/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        fondoClaro: '#f3f4f6',
        fondoOscuro: '#1f2937',
        notaAmarilla: '#fef9c3',
        notaVerde: '#d1fae5',
        notaAzul: '#bfdbfe',
        primario: '#3b82f6',
        secundario: '#f87171',
      },
    },
  },
  darkMode: 'class', // ✅ importante
  plugins: [],
}


