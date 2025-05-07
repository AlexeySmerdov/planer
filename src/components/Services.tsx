import React from 'react';

const services = [
  {
    title: 'Mobile App Development',
    description: 'Create stunning, high-performance mobile applications for iOS and Android platforms with our expert development team.',
    tags: [
      { label: 'Flutter', color: 'bg-indigo-50 text-indigo-600' },
      { label: 'FlutterFlow', color: 'bg-indigo-50 text-indigo-600' },
      { label: 'Supabase', color: 'bg-indigo-50 text-indigo-600' },
      { label: 'Firebase', color: 'bg-indigo-50 text-indigo-600' },
    ],
    icon: '/images/lightlab-services-development-options-mobile.webp',
    border: 'border-t-2 border-indigo-200',
    link: '#',
    linkColor: 'text-indigo-600',
  },
  {
    title: 'Web Development',
    description: 'Build responsive, scalable web applications with modern frameworks and technologies that deliver exceptional user experiences.',
    tags: [
      { label: 'Next.js', color: 'bg-indigo-50 text-indigo-600' },
      { label: 'Supabase', color: 'bg-indigo-50 text-indigo-600' },
      { label: 'Firebase', color: 'bg-indigo-50 text-indigo-600' },
      { label: 'React', color: 'bg-indigo-50 text-indigo-600' },
      { label: 'Tailwind CSS', color: 'bg-indigo-50 text-indigo-600' },
    ],
    icon: '/images/lightlab-services-development-options-web.webp',
    border: 'border-t-2 border-indigo-200',
    link: '#',
    linkColor: 'text-indigo-600',
  },
  {
    title: 'Business Automation',
    description: 'Streamline your business processes with custom automation workflows that save time, reduce errors, and increase productivity.',
    tags: [
      { label: 'n8n', color: 'bg-green-50 text-green-600' },
      { label: 'Custom Scripts', color: 'bg-green-50 text-green-600' },
      { label: 'Webhooks', color: 'bg-green-50 text-green-600' },
      { label: 'API Integration', color: 'bg-green-50 text-green-600' },
    ],
    icon: '/images/lightlab-services-development-options-automation.webp',
    border: 'border-t-2 border-green-200',
    link: '#',
    linkColor: 'text-green-600',
  },
  {
    title: 'AI-Powered Tools',
    description: 'Harness the power of artificial intelligence to create smart applications that learn, adapt, and deliver personalized experiences.',
    tags: [
      { label: 'Chatbots', color: 'bg-purple-50 text-purple-600' },
      { label: 'Data Analysis', color: 'bg-purple-50 text-purple-600' },
      { label: 'Content Generation', color: 'bg-purple-50 text-purple-600' },
      { label: 'Computer Vision', color: 'bg-purple-50 text-purple-600' },
    ],
    icon: '/images/lightlab-services-development-options-ai-tools.webp',
    border: 'border-t-2 border-purple-200',
    link: '#',
    linkColor: 'text-purple-600',
  },
];

export default function Services() {
  return (
    <section id="services" className="bg-white py-16">
      <div className="max-w-6xl mx-auto px-4">
        <h2 className="text-3xl font-bold text-center mb-4">Our Services</h2>
        <p className="text-center text-gray-600 mb-10">We offer a comprehensive range of digital solutions to help businesses thrive in today's technology-driven world.</p>
        <div className="grid gap-8 md:grid-cols-2 lg:grid-cols-4">
          {services.map(s => (
            <div key={s.title} className={`bg-gray-50 rounded-2xl p-8 flex flex-col items-center text-center shadow-sm hover:shadow-md transition ${s.border}`} style={{borderTopWidth: '3px'}}>
              <img src={s.icon} alt={s.title} className="w-12 h-12 mb-4" />
              <h3 className="text-lg font-bold mb-2">{s.title}</h3>
              <p className="text-gray-600 mb-4">{s.description}</p>
              <div className="flex flex-wrap justify-center gap-2 mb-4">
                {s.tags.map(tag => (
                  <span key={tag.label} className={`px-3 py-1 rounded-full text-xs font-medium ${tag.color}`}>{tag.label}</span>
                ))}
              </div>
              <a href={s.link} className={`font-semibold flex items-center gap-1 ${s.linkColor} hover:underline`}>Learn More <span aria-hidden>→</span></a>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
} 