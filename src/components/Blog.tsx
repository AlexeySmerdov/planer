import React from 'react';

const posts = [
  {
    category: 'AI Technology',
    date: 'May 15, 2025',
    title: 'How AI is Transforming Mobile App Development in 2025',
    description:
      'Explore how artificial intelligence is revolutionizing the way we build and interact with mobile applications, from personalized experiences to automated testing.',
    image: '/images/blog1.png',
  },
  {
    category: 'Automation',
    date: 'April 28, 2025',
    title: 'The Ultimate Guide to Business Process Automation',
    description:
      'Learn how to identify automation opportunities in your business and implement solutions that save time, reduce costs, and improve accuracy.',
    image: '/images/blog2.png',
  },
  {
    category: 'Web Development',
    date: 'April 10, 2025',
    title: 'Next.js vs. Other Frameworks: Which to Choose in 2025',
    description:
      'A comprehensive comparison of leading web development frameworks to help you make the right choice for your next project.',
    image: '/images/blog3.png',
  },
];

export default function Blog() {
  return (
    <section id="blog" className="bg-white py-16">
      <div className="max-w-6xl mx-auto px-4">
        <h2 className="text-3xl font-bold text-center mb-4">Our Blog</h2>
        <p className="text-center text-gray-600 mb-8">
          Stay updated with the latest technology trends, tutorials, and insights from our expert team.
        </p>
        <div className="grid gap-8 md:grid-cols-3">
          {posts.map((post) => (
            <div key={post.title} className="bg-gray-50 p-6 rounded-lg shadow-sm hover:shadow-md transition">
              <img src={post.image} alt={post.title} className="w-full h-48 object-cover rounded mb-4" />
              <div className="mb-2">
                <span className="text-indigo-600 text-sm">{post.category}</span>
                <span className="text-gray-400 text-sm ml-2">{post.date}</span>
              </div>
              <h3 className="text-xl font-semibold mb-2">{post.title}</h3>
              <p className="text-gray-600 mb-4">{post.description}</p>
              <button className="text-indigo-600 font-medium hover:underline">Read More →</button>
            </div>
          ))}
        </div>
        <div className="flex justify-center mt-8">
          <button className="px-6 py-3 bg-indigo-600 text-white rounded-full hover:bg-indigo-700">
            View All Articles
          </button>
        </div>
      </div>
    </section>
  );
} 