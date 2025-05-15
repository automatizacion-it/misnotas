#!/bin/bash

echo "🧹 Limpiando y creando nuevo proyecto Vite + React..."
npm create vite@latest . -- --template react --force

echo "📦 Instalando dependencias..."
npm install
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p

echo "🎨 Configurando Tailwind CSS..."
sed -i "s/content: \[\]/content: ['./index.html', '.\/src\/**\/*.{js,ts,jsx,tsx}']/" tailwind.config.js
echo -e "@tailwind base;\n@tailwind components;\n@tailwind utilities;" > src/index.css

echo "📝 Reemplazando App.jsx con libreta A-Z..."
cat > src/App.jsx <<EOF
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
            className={\`w-10 h-10 rounded-full font-bold \${selectedLetter === letter ? "bg-blue-400 text-white" : "bg-white"}\`}
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
              className={\`w-8 h-8 rounded-full border-2 \${color} \${selectedColor === color ? "border-black" : "border-transparent"}\`}
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
            <div key={index} className={\`p-4 rounded shadow \${note.color}\`}>
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

echo "🔧 Configurando GitHub Pages..."
npm install gh-pages --save-dev

# Detectar nombre de usuario y repositorio automáticamente
USER_NAME=$(gh api user | jq -r .login)
REPO_NAME=$(basename `git rev-parse --show-toplevel`)

# Actualizar package.json
jq '.homepage = "https://'"$USER_NAME"'.github.io/'"$REPO_NAME"'"' package.json > tmp.json && mv tmp.json package.json
jq '.scripts.deploy = "gh-pages -d dist"' package.json > tmp.json && mv tmp.json package.json

# Configurar vite.config.js
echo "import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  base: '/$REPO_NAME/',
  plugins: [react()]
})" > vite.config.js

echo "🚀 Haciendo commit y desplegando..."
git add .
git commit -m "🎉 Proyecto Vite + Libreta A-Z inicializado"
npm run build
npm run deploy

echo ""
echo "✅ Proyecto desplegado en:"
echo "🌍 https://$USER_NAME.github.io/$REPO_NAME"
