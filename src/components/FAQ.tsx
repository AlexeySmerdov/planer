'use client';
import { useState } from 'react';

const faqs = [
  {
    question: 'What is your development process?',
    answer: `At LightLab, we follow a clear, iterative development process:

- Discovery & Planning – We begin with understanding your business goals, audience, and technical requirements.
- UI/UX Design – We prototype and design user-friendly interfaces in Figma, tailored to your brand.
- Development – Using Flutter, FlutterFlow, or Next.js with Firebase or Supabase, we build fast and scalable apps.
- Testing – Rigorous testing ensures your app is reliable and bug-free across platforms.
- Launch – We assist with deployment to the App Store, Google Play, or the web.
- Post-Launch Support – We offer ongoing maintenance, updates, and improvements based on user feedback.

Every step is transparent. You'll always know what we're doing and why.`
  },
  {
    question: 'How much does a typical project cost?',
    answer: `Project costs vary depending on features, platforms (iOS, Android, Web), and complexity. On average:

- MVP apps (3–4 screens, basic logic): from $3,000 to $5,000
- Medium apps (auth, payments, integrations): $6,000 to $15,000
- Custom apps with AI & backend: $15,000+

We offer flexible pricing models (fixed-price, hourly, or phased milestones) to match your needs and budget.`
  },
  {
    question: 'How long does it take to develop an app?',
    answer: `Timelines depend on the app's complexity:

- MVP: 3–5 weeks
- Standard business app: 6–10 weeks
- Full-scale or AI-integrated app: 10–16 weeks

We work in agile sprints and deliver frequent updates. If speed is critical, we can accelerate delivery with no-code tools like FlutterFlow.`
  },
  {
    question: 'Do you provide ongoing support after launch?',
    answer: `Yes! We offer several tiers of post-launch support:

- Bug fixes & maintenance
- App updates for OS changes
- Feature expansions
- Analytics & performance tracking
- AI model improvements (if used)

Support can be one-time, subscription-based, or part of a service-level agreement (SLA). We want your app to grow with your business.`
  },
  {
    question: 'How do you integrate AI into applications?',
    answer: `We seamlessly integrate AI to improve user experience and automate workflows. Some examples:

- Chatbots & virtual assistants using OpenAI/Gemini APIs
- Image & text recognition (OCR, food recognition, emotion detection)
- AI-powered recommendations (fitness, e-commerce, education)
- Natural language processing for smart search, summaries, and translations

We handle everything: from prompt engineering and API integration to UX and scalability on Firebase or Supabase.`
  },
];

export default function FAQ() {
  const [openIndex, setOpenIndex] = useState<number | null>(null);
  const toggle = (index: number) => setOpenIndex(openIndex === index ? null : index);

  return (
    <section id="faq" className="bg-gray-50 py-16">
      <div className="max-w-6xl mx-auto px-4">
        <h2 className="text-3xl font-bold text-center mb-4">Frequently Asked Questions</h2>
        <p className="text-center text-gray-600 mb-8">
          Get answers to common questions about our services, process, and technology.
        </p>
        <div className="space-y-4">
          {faqs.map((faq, i) => (
            <div key={faq.question}>
              <button
                onClick={() => toggle(i)}
                className="w-full bg-white p-4 border rounded-lg flex justify-between items-center hover:bg-gray-50"
              >
                <span className="text-gray-900 text-left flex-1">{faq.question}</span>
                <svg
                  className={`w-6 h-6 text-gray-400 transform transition-transform ${openIndex === i ? 'rotate-180' : ''}`}
                  fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"
                >
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                </svg>
              </button>
              {openIndex === i && (
                <div className="bg-white border border-t-0 rounded-b-lg px-6 py-4 text-gray-700 whitespace-pre-line">
                  {faq.answer}
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </section>
  );
} 