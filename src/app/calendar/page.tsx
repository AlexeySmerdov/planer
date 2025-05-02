'use client';

import { useEffect, useState } from 'react';
import FullCalendar from '@fullcalendar/react';
import dayGridPlugin from '@fullcalendar/daygrid';
import { Task } from '@/types/task';
import { getTaskStore } from '@/utils/taskStorage';

export default function Calendar() {
  const [events, setEvents] = useState<any[]>([]);

  useEffect(() => {
    const store = getTaskStore();
    const calendarEvents = store.tasks.map(task => ({
      id: task.id,
      title: task.title,
      date: task.date,
      backgroundColor: task.completed ? '#10B981' : '#3B82F6',
      url: `/task/${task.id}`
    }));
    setEvents(calendarEvents);
  }, []);

  return (
    <div className="max-w-6xl mx-auto">
      <h1 className="text-3xl font-bold mb-8">Task Calendar</h1>
      <div className="bg-white p-4 rounded-lg shadow">
        <FullCalendar
          plugins={[dayGridPlugin]}
          initialView="dayGridMonth"
          events={events}
          height="auto"
          headerToolbar={{
            left: 'prev,next today',
            center: 'title',
            right: 'dayGridMonth,dayGridWeek'
          }}
        />
      </div>
    </div>
  );
} 