import { useEffect, useState } from "react";

import TaskForm from "../components/TaskForm";
import TaskList from "../components/TaskList";

import {
  getTasks,
  createTask,
  updateTask,
  deleteTask,
} from "../services/taskApi";

function TasksPage() {
  const [tasks, setTasks] = useState([]);

  async function loadTasks() {
    const data = await getTasks();
    setTasks(data);
  }

  useEffect(() => {
    loadTasks();
  }, []);

  async function handleCreate(titulo) {
    await createTask({
      titulo,
      completada: false,
    });

    await loadTasks();
  }

  async function handleToggle(task) {
    await updateTask(task.id, {
      ...task,
      completada: !task.completada,
    });

    await loadTasks();
  }

  async function handleDelete(id) {
    await deleteTask(id);

    await loadTasks();
  }

  return (
  <div className="container">
    <h1>Task UI</h1>

    <p className="subtitle">
      Gestión de tareas con React y Express
    </p>

    <TaskForm onCreate={handleCreate} />

    <TaskList
      tasks={tasks}
      onToggle={handleToggle}
      onDelete={handleDelete}
    />
  </div>
)
}

export default TasksPage;