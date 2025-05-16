import { useState, useEffect, useRef } from "react";

const letters = Array.from({ length: 26 }, (_, i) => String.fromCharCode(65 + i));
const colors = ["bg-yellow-100", "bg-green-100", "bg-blue-100"];

export default function LibretaNotas() {
  const [selectedLetter, setSelectedLetter] = useState("A");
  const [notes, setNotes] = useState({});
  const [newNoteText, setNewNoteText] = useState("");
  const [selectedColor, setSelectedColor] = useState(colors[0]);
  const lastDeletedNote = useRef(null); // ← referencia para la nota borrada

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

  const handleDeleteNote = (indexToDelete) => {
    const confirmDelete = window.confirm("¿Estás seguro de que deseas borrar esta nota?");
    if (!confirmDelete) return;

    setNotes((prev) => {
      const currentNotes = [...(prev[selectedLetter] || [])];
      const deleted = currentNotes.splice(indexToDelete, 1)[0];
      lastDeletedNote.current = { letter: selectedLetter, note: deleted }; // ← guardar nota eliminada
      return {
        ...prev,
        [selectedLetter]: currentNotes,
      };
    });
  };

  const handleUndoDelete = () => {
    if (!lastDeletedNote.current) return;

    const { letter, note } = lastDeletedNote.current;
    setNotes((prev) => ({
      ...prev,
      [letter]: [...(prev[letter] || []), note],
    }));
    lastDeletedNote.current = null; // ← limpiar
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

        <div className="flex items-center space-x-2">
          <button
            onClick={handleAddNote}
            className="bg-blue-500 text-white px-4 py-2 rounded"
          >
            Agregar Nota
          </button>
          {lastDeletedNote.current && (
            <button
              onClick={handleUndoDelete}
              className="bg-gray-300 text-black px-4 py-2 rounded"
            >
              Deshacer
            </button>
          )}
        </div>

        <div className="mt-4 space-y-4">
          {(notes[selectedLetter] || []).map((note, index) => (
            <div
              key={index}
              className={`p-4 rounded shadow ${note.color} relative`}
            >
              <div className="text-sm text-gray-600">{note.timestamp}</div>
              <div>{note.text}</div>
              <button
                onClick={() => handleDeleteNote(index)}
                className="absolute top-2 right-2 text-xs text-red-600 hover:underline"
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
