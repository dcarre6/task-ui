function TaskItem({ task, onToggle, onDelete }) {
  return (
    <div className="task-card">
  <h3 className="task-title">
    {task.completada ? "✅" : "⏳"} {task.titulo}
  </h3>

  <div className="task-actions">
    <button
      className="btn-success"
      onClick={() => onToggle(task)}
    >
      Completar
    </button>

    <button
      className="btn-danger"
      onClick={() => onDelete(task.id)}
    >
      Eliminar
    </button>
  </div>
</div>
  );
}

export default TaskItem;