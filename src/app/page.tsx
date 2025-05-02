'use client';

import { useEffect, useState } from 'react';
import { Task } from '@/types/task';
import { getTasksByDate, getTaskStore } from '@/utils/taskStorage';
import Link from 'next/link';
import FullCalendar from '@fullcalendar/react';
import dayGridPlugin from '@fullcalendar/daygrid';

export default function Home() {
  const [todaysTasks, setTodaysTasks] = useState<Task[]>([]);
  const [calendarEvents, setCalendarEvents] = useState<any[]>([]);

  useEffect(() => {
    // Load today's tasks
    const today = new Date().toISOString().split('T')[0];
    const tasks = getTasksByDate(today);
    setTodaysTasks(tasks);

    // Load calendar events
    const store = getTaskStore();
    const events = store.tasks.map(task => ({
      id: task.id,
      title: task.title,
      date: task.date,
      backgroundColor: task.completed ? '#10B981' : '#3B82F6',
      url: `/task/${task.id}`
    }));
    setCalendarEvents(events);
  }, []);

  return (
    <div className="max-w-6xl mx-auto">
      {/* Header Section */}
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">Welcome to Task Planner</h1>
        <p className="mt-2 text-gray-600">Manage your tasks efficiently and stay organized</p>
      </div>

      {/* Calendar Section */}
      <div className="card mb-8">
        <h2 className="text-xl font-semibold mb-4">Calendar View</h2>
        <FullCalendar
          plugins={[dayGridPlugin]}
          initialView="dayGridMonth"
          events={calendarEvents}
          height="auto"
          headerToolbar={{
            left: 'prev,next today',
            center: 'title',
            right: 'dayGridMonth,dayGridWeek'
          }}
        />
      </div>

      {/* Today's Tasks Section */}
      <div className="card mb-8">
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-xl font-semibold">Today's Tasks</h2>
          <Link href="/new-task" className="btn btn-primary">
            Add New Task
          </Link>
        </div>

        {todaysTasks.length === 0 ? (
          <div className="text-center py-6">
            <p className="text-gray-500">No tasks scheduled for today</p>
            <Link href="/new-task" className="text-blue-500 hover:text-blue-600 mt-2 inline-block">
              Create your first task →
            </Link>
          </div>
        ) : (
          <div className="space-y-4">
            {todaysTasks.map(task => (
              <div key={task.id} className="border rounded-lg p-4 hover:bg-gray-50">
                <div className="flex justify-between items-center">
                  <h3 className="font-medium">{task.title}</h3>
                  <span className={task.completed ? 'text-green-600' : 'text-yellow-600'}>
                    {task.completed ? 'Completed' : 'Pending'}
                  </span>
                </div>
                <p className="text-gray-600 mt-2">{task.description}</p>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Quick Actions Section */}
      <div className="card">
        <h2 className="text-xl font-semibold mb-4">Quick Actions</h2>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <Link href="/new-task" className="btn btn-primary w-full text-center">
            Create Task
          </Link>
          <Link href="/calendar" className="btn btn-secondary w-full text-center">
            Full Calendar View
          </Link>
        </div>
      </div>
    </div>
  );
} 