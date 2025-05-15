#!/bin/bash

echo "🧹 Limpiando y creando nuevo proyecto Vite + React..."
npm create vite@latest . -- --template react --force

echo "📦 Instalando dependencias base..."
npm install
npm install -D tailwindcss postcss autoprefixer @vitejs/plugin-react
npx tailwindcss init -p

echo "🎨 Configurando Tailwind CSS..."
sed -i "s/content: \[\]/content: ['./index.html', '.\/src\/**\/*.{js,ts,jsx,tsx}']/" tailwind.config.js
echo -e "@tailwind base;\n@tailwind components;\n@tailwind utilities;" > src/index.css

echo "📝 Reemplazando App.jsx con libreta A-Z..."
cat > src/App.jsx <<'EOF'
import { useState, useEffect } from "react";

const letters = Array.from({ length: 26 }, (_, i) => String.fromCharCode(65 + i));
const colors = ["bg-yellow-100", "bg-green-100", "bg-blue-100"];

export default function LibretaNotas() {
  const [selectedLetter, setSelectedLetter] = useState("A");
  const [notes, setNotes] = useState({});
  const [newNoteText, setNewNoteText] = useState("");
  const [selectedColor, setSelectedColor] = useState(colors[0]);

  useEffect(() => {
    const savedNotes = JSON.parse(localStorage.getItem("libretaNotas")) || {};
    setNotes(savedNotes);
  }, []);

  useEffect(() => {
    localStorage.setItem("libretaNotas", JSON.stringify(notes));
  }, [notes]);

  const handleAddNote = () => {
    if (!newNoteText.trim()) return;
    const timestamp = new Date().toLocaleString();
    const note = { text: newNoteText, timestamp, color: selectedColor };
    setNotes((prev) => ({
      ...prev,
      [selectedLetter]: [...(prev[selectedLetter] || []), note],
    }));
    setNewNoteText("");
  };

  return (
    <div className="flex h-screen">
      <aside className="w-16 bg-gray-100 p-2 flex flex-col items-center space-y-2 overflow-y-auto">
        {letters.map((letter) => (
          <button
            key={letter}
            onClick={() => setSelectedLetter(letter)}
            className={`w-10 h-10 rounded-full font-bold ${
              selectedLetter === letter ? "bg-blue-400 text-white" : "bg-white"
            }`}
          >
            {letter}
          </button>
        ))}
      </aside>

      <main className="flex-1 p-4 overflow-y-auto">
        <h1 className="text-xl font-bold mb-4">Notas para la letra "{selectedLetter}"</h1>

        <div className="flex space-x-2 mb-2">
          {colors.map((color) => (
            <button
              key={color}
              className={`w-8 h-8 rounded-full border-2 ${color} ${
                selectedColor === color ? "border-black" : "border-transparent"
              }`}
              onClick={() => setSelectedColor(color)}
            />
          ))}
        </div>

        <textarea
          value={newNoteText}
          onChange={(e) => setNewNoteText(e.target.value)}
          rows={3}
          className="w-full p-2 border rounded mb-2"
          placeholder="Escribe una nota..."
        />

        <button
          onClick={handleAddNote}
          className="bg-blue-500 text-white px-4 py-2 rounded"
        >
          Agregar Nota
        </button>

        <div className="mt-4 space-y-4">
          {(notes[selectedLetter] || []).map((note, index) => (
            <div key={index} className={`p-4 rounded shadow ${note.color}`}>
              <div className="text-sm text-gray-600">{note.timestamp}</div>
              <div>{note.text}</div>
            </div>
          ))}
        </div>
      </main>
    </div>
  );
}
EOF

echo "🔧 Configurando vite.config.js..."
cat > vite.config.js <<EOF
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  base: '',
})
EOF

echo "✅ Proyecto configurado. Para ejecutarlo localmente, corre:"
echo "   npm run dev"

echo ""
echo "📌 Si deseas desplegar en GitHub Pages, asegúrate de:"
echo "1. Ejecutar:    npm run build"
echo "2. Instalar:    npm install gh-pages --save-dev"
echo "3. Agregar en package.json:"
echo '   "deploy": "gh-pages -d dist"'
echo "4. Luego:       npm run deploy"
