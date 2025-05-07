import React from 'react';

export default function Footer() {
  return (
    <footer className="bg-gray-900 text-gray-300 py-12">
      <div className="max-w-6xl mx-auto px-4 grid grid-cols-1 md:grid-cols-3 gap-8">
        <div>
          <h3 className="text-xl font-bold text-white mb-2">LightLab</h3>
          <p className="text-gray-400">
            Innovative software solutions that illuminate your business potential through cutting-edge technology.
          </p>
        </div>
        <div>
          <h4 className="text-lg font-semibold text-white mb-2">Contact</h4>
          <ul className="space-y-1">
            <li>
              <a href="mailto:aleksei@lightlab.com" className="hover:text-white">
              aleksei@lightlab.com
              </a>
            </li>
            <li>
              <a href="tel:+16505566310" className="hover:text-white">
                +1 (650) 556-63-10
              </a>
            </li>
            <li>
              <span>Houston, Tx</span>
            </li>
          </ul>
        </div>
        <div>
          <h4 className="text-lg font-semibold text-white mb-2">Follow Us</h4>
          <div className="flex space-x-4">
            <a href="#" className="hover:text-white">Twitter</a>
            <a href="#" className="hover:text-white">LinkedIn</a>
            <a href="#" className="hover:text-white">GitHub</a>
          </div>
        </div>
      </div>
      <div className="mt-8 text-center text-gray-500 text-sm">
        &copy; {new Date().getFullYear()} LightLab. All rights reserved.
      </div>
    </footer>
  );
} 