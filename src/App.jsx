import { useState, useEffect } from "react";

const letters = Array.from({ length: 26 }, (_, i) => String.fromCharCode(65 + i));
const colors = ["notaAmarilla", "notaVerde", "notaAzul"];

export default function LibretaNotas() {
  const [selectedLetter, setSelectedLetter] = useState("A");
  const [notes, setNotes] = useState({});
  const [newNoteText, setNewNoteText] = useState("");
  const [selectedColor, setSelectedColor] = useState(colors[0]);
  const [darkMode, setDarkMode] = useState(false);

  useEffect(() => {
    const savedNotes = JSON.parse(localStorage.getItem("libretaNotas")) || {};
    setNotes(savedNotes);
  }, []);

  useEffect(() => {
    localStorage.setItem("libretaNotas", JSON.stringify(notes));
  }, [notes]);

  useEffect(() => {
    document.documentElement.classList.toggle("dark", darkMode);
  }, [darkMode]);

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

  const handleDeleteNote = (indexToDelete) => {
    setNotes((prev) => ({
      ...prev,
      [selectedLetter]: prev[selectedLetter].filter((_, i) => i !== indexToDelete),
    }));
  };

  return (
    <div className="flex h-screen bg-fondoClaro dark:bg-fondoOscuro text-gray-800 dark:text-gray-100">
      <aside className="w-16 bg-white dark:bg-gray-800 border-r border-gray-300 dark:border-gray-600 p-2 flex flex-col items-center space-y-2 overflow-y-auto shadow-md">
        {letters.map((letter) => (
          <button
            key={letter}
            onClick={() => setSelectedLetter(letter)}
            className={`w-10 h-10 rounded-full font-bold ${
              selectedLetter === letter ? "bg-primario text-white" : "bg-white dark:bg-gray-700"
            }`}
          >
            {letter}
          </button>
        ))}
      </aside>

      <main className="flex-1 p-4 overflow-y-auto">
        <div className="flex justify-between items-center mb-4">
          <h1 className="text-xl font-bold">Notas para la letra "{selectedLetter}"</h1>
          <button
            onClick={() => setDarkMode(!darkMode)}
            className="text-sm text-gray-600 dark:text-gray-300 hover:underline"
          >
            {darkMode ? "Modo Claro" : "Modo Oscuro"}
          </button>
        </div>

        <div className="flex space-x-2 mb-2">
          {colors.map((color) => (
            <button
              key={color}
              className={`w-8 h-8 rounded-full border-2 bg-${color} ${
                selectedColor === color ? "border-black dark:border-white" : "border-transparent"
              }`}
              onClick={() => setSelectedColor(color)}
            />
          ))}
        </div>

        <textarea
          value={newNoteText}
          onChange={(e) => setNewNoteText(e.target.value)}
          rows={3}
          className="w-full p-2 border rounded mb-2 dark:bg-gray-700 dark:text-white"
          placeholder="Escribe una nota..."
        />

        <button
          onClick={handleAddNote}
          className="bg-primario text-white px-4 py-2 rounded"
        >
          Agregar Nota
        </button>

        <div className="mt-4 space-y-4">
          {(notes[selectedLetter] || []).map((note, index) => (
            <div key={index} className={`p-4 rounded shadow bg-${note.color}`}>
              <div className="text-sm text-gray-600 dark:text-gray-300">{note.timestamp}</div>
              <div className="mb-2">{note.text}</div>
              <button
                onClick={() => handleDeleteNote(index)}
                className="text-secundario text-sm hover:underline"
              >
                Borrar
              </button>
            </div>
          ))}
        </div>
      </main>
    </div>
  );
}
