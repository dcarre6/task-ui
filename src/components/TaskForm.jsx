import { useState } from "react";

function TaskForm({ onCreate }) {
  const [titulo, setTitulo] = useState("");

  function handleSubmit(event) {
    event.preventDefault();

    if (!titulo.trim()) {
      return;
    }

    onCreate(titulo);

    setTitulo("");
  }

  return (
    <form className="task-form" onSubmit={handleSubmit}>
      <input
        value={titulo}
        onChange={(e) => setTitulo(e.target.value)}
        placeholder="Nueva tarea"
      />

      <button 
      type="submit"
      className="btn-primary">
        Crear
      </button>
    </form>
  );
}

export default TaskForm;