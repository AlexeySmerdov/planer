import React from 'react';

export default function AboutUs() {
  return (
    <section id="about-us" className="bg-gray-50 py-16">
      <div className="max-w-6xl mx-auto px-4 space-y-12">
        {/* About Us Intro */}
        <div className="text-center">
          <h2 className="text-3xl font-bold mb-4">About Us</h2>
          <p className="text-lg text-gray-700">
            LightLab is a team of passionate developers, designers, and strategists dedicated to creating technology solutions that make a difference.
          </p>
        </div>

        {/* Cards Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8">
          {/* Mission */}
          <div className="bg-white rounded-2xl p-8 flex flex-col items-center text-center shadow-sm">
            <img src="/images/our-mission.webp" alt="Mission" className="w-14 h-14 mb-4" />
            <h3 className="text-xl font-bold mb-2">Our Mission</h3>
            <p className="text-gray-700">To illuminate businesses with powerful software solutions that drive growth and efficiency through innovation and technology.</p>
          </div>
          {/* Values */}
          <div className="bg-white rounded-2xl p-8 flex flex-col items-center text-center shadow-sm">
            <img src="/images/our-values.webp" alt="Values" className="w-14 h-14 mb-4" />
            <h3 className="text-xl font-bold mb-2">Our Values</h3>
            <p className="text-gray-700">We believe in transparency, continuous learning, client collaboration, and delivering excellence in every project we undertake.</p>
          </div>
          {/* Team */}
          <div className="bg-white rounded-2xl p-8 flex flex-col items-center text-center shadow-sm">
            <img src="/images/our-team.webp" alt="Team" className="w-14 h-14 mb-4" />
            <h3 className="text-xl font-bold mb-2">Our Team</h3>
            <p className="text-gray-700">With over 15 years of combined experience, our experts bring diverse skills to create holistic digital solutions for businesses of all sizes.</p>
          </div>
          {/* Approach */}
          <div className="bg-white rounded-2xl p-8 flex flex-col items-center text-center shadow-sm">
            <img src="/images/our-approach.webp" alt="Approach" className="w-14 h-14 mb-4" />
            <h3 className="text-xl font-bold mb-2">Our Approach</h3>
            <p className="text-gray-700">We focus on future-proof solutions, leveraging automation and AI to create scalable, efficient, and intelligent applications.</p>
          </div>
        </div>
      </div>
    </section>
  );
} 