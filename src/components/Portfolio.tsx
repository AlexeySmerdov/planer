'use client';
import React, { useState } from 'react';

const filters = ['All', 'Mobile Apps', 'Web Apps', 'Automation', 'AI Solutions'];
const projects = [
  { title: 'FitTrack Pro', category: 'Mobile Apps', description: 'A comprehensive fitness tracking application with AI-powered workout recommendations.', image: '/images/fittrack.png' },
  { title: 'PropManager', category: 'Web Apps', description: 'A property management platform with automated tenant communications.', image: '/images/propmanager.png' },
  // add more dummy projects...
];

export default function Portfolio() {
  const [activeFilter, setActiveFilter] = useState('All');
  const filtered = activeFilter === 'All' ? projects : projects.filter(p => p.category === activeFilter);

  return (
    <section id="portfolio" className="bg-gray-50 py-16">
      <div className="max-w-6xl mx-auto px-4">
        <h2 className="text-3xl font-bold text-center mb-8">Our Portfolio</h2>
        <div className="flex justify-center space-x-4 mb-8">
          {filters.map(f => (
            <button
              key={f}
              onClick={() => setActiveFilter(f)}
              className={`px-4 py-2 rounded-full ${activeFilter === f ? 'bg-indigo-600 text-white' : 'bg-white text-gray-700 border'}`}
            >
              {f}
            </button>
          ))}
        </div>
        <div className="grid gap-8 md:grid-cols-2 lg:grid-cols-3">
          {filtered.map(p => (
            <div key={p.title} className="p-6 bg-white rounded-lg shadow-sm hover:shadow-md transition">
              <img src={p.image} alt={p.title} className="w-full h-40 object-cover rounded mb-4" />
              <h3 className="text-xl font-semibold mb-2">{p.title}</h3>
              <p className="text-gray-600 mb-4">{p.description}</p>
              <button className="text-indigo-600 font-medium hover:underline">Learn More →</button>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
} 