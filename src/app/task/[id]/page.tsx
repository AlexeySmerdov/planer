'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { Task, Comment } from '@/types/task';
import { getTaskById, updateTask, deleteTask } from '@/utils/taskStorage';
import { v4 as uuidv4 } from 'uuid';

export default function TaskDetail({ params }: { params: { id: string } }) {
  const router = useRouter();
  const [task, setTask] = useState<Task | null>(null);
  const [newComment, setNewComment] = useState('');

  useEffect(() => {
    const taskData = getTaskById(params.id);
    if (taskData) {
      setTask(taskData);
    } else {
      router.push('/');
    }
  }, [params.id, router]);

  if (!task) {
    return <div>Loading...</div>;
  }

  const handleToggleComplete = () => {
    const updatedTask = { ...task, completed: !task.completed };
    updateTask(updatedTask);
    setTask(updatedTask);
  };

  const handleAddComment = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newComment.trim()) return;

    const comment: Comment = {
      id: uuidv4(),
      text: newComment,
      createdAt: new Date().toISOString()
    };

    const updatedTask = {
      ...task,
      comments: [...task.comments, comment]
    };

    updateTask(updatedTask);
    setTask(updatedTask);
    setNewComment('');
  };

  const handleDelete = () => {
    if (window.confirm('Are you sure you want to delete this task?')) {
      deleteTask(task.id);
      router.push('/');
    }
  };

  return (
    <div className="max-w-4xl mx-auto">
      <div className="flex items-center justify-between mb-8">
        <h1 className="text-3xl font-bold">{task.title}</h1>
        <div className="space-x-4">
          <button
            onClick={handleToggleComplete}
            className={`px-4 py-2 rounded-lg ${
              task.completed
                ? 'bg-green-500 hover:bg-green-600'
                : 'bg-yellow-500 hover:bg-yellow-600'
            } text-white transition-colors`}
          >
            {task.completed ? 'Completed' : 'Mark Complete'}
          </button>
          <button
            onClick={handleDelete}
            className="px-4 py-2 rounded-lg bg-red-500 hover:bg-red-600 text-white transition-colors"
          >
            Delete
          </button>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow-sm p-6 mb-8">
        <div className="mb-6">
          <h2 className="text-xl font-semibold mb-2">Description</h2>
          <p className="text-gray-600">{task.description}</p>
        </div>

        <div className="mb-6">
          <h2 className="text-xl font-semibold mb-2">Date</h2>
          <p className="text-gray-600">{new Date(task.date).toLocaleDateString()}</p>
        </div>

        {task.images.length > 0 && (
          <div className="mb-6">
            <h2 className="text-xl font-semibold mb-4">Images</h2>
            <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
              {task.images.map((image, index) => (
                <img
                  key={index}
                  src={image}
                  alt={`Task image ${index + 1}`}
                  className="w-full h-48 object-cover rounded-lg"
                />
              ))}
            </div>
          </div>
        )}

        <div>
          <h2 className="text-xl font-semibold mb-4">Comments</h2>
          <form onSubmit={handleAddComment} className="mb-4">
            <div className="flex gap-2">
              <input
                type="text"
                value={newComment}
                onChange={(e) => setNewComment(e.target.value)}
                placeholder="Add a comment..."
                className="flex-1 rounded-lg border-gray-300 focus:border-blue-500 focus:ring-blue-500"
              />
              <button
                type="submit"
                className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
              >
                Add
              </button>
            </div>
          </form>

          <div className="space-y-4">
            {task.comments.map(comment => (
              <div key={comment.id} className="bg-gray-50 rounded-lg p-4">
                <p className="text-gray-800">{comment.text}</p>
                <p className="text-sm text-gray-500 mt-2">
                  {new Date(comment.createdAt).toLocaleString()}
                </p>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
} 