import Link from 'next/link';
import React from 'react';

const navItems = [
  { label: 'About Us', href: '#about-us' },
  { label: 'Services', href: '#services' },
  { label: 'Portfolio', href: '#portfolio' },
  { label: 'Blog', href: '#blog' },
  { label: 'FAQ', href: '#faq' },
  { label: 'Contact', href: '#contact' },
];

export default function Navbar() {
  return (
    <nav className="bg-white shadow">
      <div className="max-w-6xl mx-auto px-4 flex justify-between items-center py-4">
        <Link href="/" className="text-2xl font-bold text-indigo-600">LightLab</Link>
        <ul className="hidden md:flex space-x-6">
          {navItems.map(item => (
            <li key={item.href}>
              <Link href={item.href} className="text-gray-600 hover:text-gray-900">
                {item.label}
              </Link>
            </li>
          ))}
        </ul>
        <Link
          href="#contact"
          className="hidden md:inline-block bg-indigo-600 text-white px-4 py-2 rounded-full hover:bg-indigo-700"
        >
          Book a Consultation
        </Link>
      </div>
    </nav>
  );
} 