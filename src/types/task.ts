export interface Task {
  id: string;
  title: string;
  description: string;
  date: string;
  completed: boolean;
  images: string[]; // base64 encoded images
  comments: Comment[];
}

export interface Comment {
  id: string;
  text: string;
  createdAt: string;
}

export interface TaskStore {
  tasks: Task[];
} 