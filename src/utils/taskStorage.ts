import { Task, TaskStore } from '../types/task';
import { v4 as uuidv4 } from 'uuid';

const STORAGE_KEY = 'task-store';

export const getTaskStore = (): TaskStore => {
  if (typeof window === 'undefined') return { tasks: [] };
  
  const stored = localStorage.getItem(STORAGE_KEY);
  if (!stored) return { tasks: [] };
  
  try {
    return JSON.parse(stored);
  } catch {
    return { tasks: [] };
  }
};

export const saveTaskStore = (store: TaskStore): void => {
  if (typeof window === 'undefined') return;
  localStorage.setItem(STORAGE_KEY, JSON.stringify(store));
};

export const addTask = (task: Omit<Task, 'id'>): Task => {
  const store = getTaskStore();
  const newTask = { ...task, id: uuidv4() };
  store.tasks.push(newTask);
  saveTaskStore(store);
  return newTask;
};

export const updateTask = (task: Task): void => {
  const store = getTaskStore();
  const index = store.tasks.findIndex(t => t.id === task.id);
  if (index !== -1) {
    store.tasks[index] = task;
    saveTaskStore(store);
  }
};

export const deleteTask = (taskId: string): void => {
  const store = getTaskStore();
  store.tasks = store.tasks.filter(task => task.id !== taskId);
  saveTaskStore(store);
};

export const getTaskById = (taskId: string): Task | undefined => {
  const store = getTaskStore();
  return store.tasks.find(task => task.id === taskId);
};

export const getTasksByDate = (date: string): Task[] => {
  const store = getTaskStore();
  return store.tasks.filter(task => task.date === date);
}; 