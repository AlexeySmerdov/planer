import React from 'react';

export default function WhyChoose() {
  return (
    <section className="py-12">
      <div className="max-w-6xl mx-auto px-4">
        <div className="bg-indigo-50 rounded-3xl flex flex-col lg:flex-row overflow-hidden">
          {/* Left: Text */}
          <div className="flex-1 p-10 flex flex-col justify-center">
            <h2 className="text-3xl font-bold mb-6 text-gray-900">Why Choose LightLab?</h2>
            <ul className="space-y-4 text-lg text-gray-700">
              <li className="flex items-start gap-3">
                <span className="text-indigo-500 mt-1">✔</span>
                Specialized in AI-powered solutions that learn and adapt
              </li>
              <li className="flex items-start gap-3">
                <span className="text-indigo-500 mt-1">✔</span>
                Custom automation workflows that save time and reduce costs
              </li>
              <li className="flex items-start gap-3">
                <span className="text-indigo-500 mt-1">✔</span>
                Cross-platform expertise from mobile to web to backend systems
              </li>
              <li className="flex items-start gap-3">
                <span className="text-indigo-500 mt-1">✔</span>
                Agile development methodology with regular client updates
              </li>
              <li className="flex items-start gap-3">
                <span className="text-indigo-500 mt-1">✔</span>
                Ongoing support and maintenance for all delivered projects
              </li>
            </ul>
          </div>
          {/* Right: Image */}
          <div className="flex-1 min-h-[320px] flex items-center justify-center bg-white">
            <img
              src="/images/why-choose-lightlab.webp"
              alt="Why Choose LightLab"
              className="w-full h-full object-cover object-center rounded-3xl lg:rounded-none lg:rounded-r-3xl"
              style={{maxHeight: 400}}
            />
          </div>
        </div>
      </div>
    </section>
  );
} 