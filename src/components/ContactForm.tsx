'use client';
import React, { useState } from 'react';

export default function ContactForm() {
  const [form, setForm] = useState({ name: '', email: '', company: '', service: '', details: '' });
  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };
  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // TODO: handle submission
    console.log(form);
  };

  return (
    <section id="contact" className="bg-white py-16">
      <div className="max-w-6xl mx-auto px-4">
        <h2 className="text-3xl font-bold text-center mb-4">Let's Bring Your Ideas to Life</h2>
        <p className="text-center text-gray-600 mb-8">
          Ready to start your project? Contact us today for a free consultation.
        </p>
        <form onSubmit={handleSubmit} className="max-w-2xl mx-auto space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <input
              name="name"
              type="text"
              placeholder="Your Name"
              value={form.name}
              onChange={handleChange}
              required
              className="w-full border-gray-300 rounded-lg shadow-sm focus:border-indigo-600 focus:ring-indigo-600 p-3"
            />
            <input
              name="email"
              type="email"
              placeholder="Your Email"
              value={form.email}
              onChange={handleChange}
              required
              className="w-full border-gray-300 rounded-lg shadow-sm focus:border-indigo-600 focus:ring-indigo-600 p-3"
            />
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <input
              name="company"
              type="text"
              placeholder="Company Name"
              value={form.company}
              onChange={handleChange}
              className="w-full border-gray-300 rounded-lg shadow-sm focus:border-indigo-600 focus:ring-indigo-600 p-3"
            />
            <select
              name="service"
              value={form.service}
              onChange={handleChange}
              className="w-full border-gray-300 rounded-lg shadow-sm focus:border-indigo-600 focus:ring-indigo-600 p-3"
            >
              <option value="">Service Interested In</option>
              <option value="Mobile App Development">Mobile App Development</option>
              <option value="Web Development">Web Development</option>
              <option value="Business Automation">Business Automation</option>
              <option value="AI-Powered Tools">AI-Powered Tools</option>
            </select>
          </div>
          <textarea
            name="details"
            placeholder="Project Details"
            value={form.details}
            onChange={handleChange}
            className="w-full border-gray-300 rounded-lg shadow-sm focus:border-indigo-600 focus:ring-indigo-600 p-3 h-32"
          />
          <button
            type="submit"
            className="w-full px-6 py-3 bg-indigo-600 text-white font-medium rounded-full hover:bg-indigo-700"
          >
            Send Message
          </button>
        </form>
      </div>
    </section>
  );
} 