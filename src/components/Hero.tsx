export default function Hero() {
  return (
    <section id="hero" className="bg-gradient-to-r from-indigo-50 to-purple-50">
      <div className="max-w-6xl mx-auto px-4 py-32 md:py-40 flex flex-col-reverse lg:flex-row items-center">
        <div className="flex-[3] text-center lg:text-left max-w-2xl">
          <h1 className="text-4xl sm:text-5xl md:text-6xl lg:text-5xl font-bold text-gray-900 mb-6">
            <span>Light in the code, </span>
            <span className="block text-indigo-600">growth on the screen</span>
          </h1>
          <p className="text-lg sm:text-xl text-gray-700 mb-8">
            We build powerful mobile and web applications enhanced with AI integration and business automation to help your business thrive in the digital landscape.
          </p>
          <div className="flex justify-center lg:justify-start space-x-6">
            <a href="#contact" className="inline-block bg-indigo-600 text-white px-8 py-4 rounded-full hover:bg-indigo-700 transition">
              Book a Consultation
            </a>
            <a href="#portfolio" className="inline-block border-2 border-indigo-600 text-indigo-600 px-8 py-4 rounded-full hover:bg-indigo-50 transition">
              See Our Work
            </a>
          </div>
          <div className="flex flex-wrap justify-center lg:justify-start gap-x-4 gap-y-4 mt-8">
            <div className="inline-flex items-center bg-white border border-gray-200 rounded-full px-3 py-1 shadow-sm space-x-2 text-sm">
              <img src="images/nextjs-framework-logo.webp" alt="Next.js" className="w-5 h-5" />
              <span>Next.js</span>
            </div>
            <div className="inline-flex items-center bg-white border border-gray-200 rounded-full px-3 py-1 shadow-sm space-x-2 text-sm">
              <img src="images/flutter-mobile-development-logo.webp" alt="Flutter" className="w-5 h-5" />
              <span>Flutter</span>
            </div>
            <div className="inline-flex items-center bg-white border border-gray-200 rounded-full px-3 py-1 shadow-sm space-x-2 text-sm">
              <img src="images/supabase-database-logo.webp" alt="Supabase" className="w-5 h-5" />
              <span>Supabase</span>
            </div>
            <div className="inline-flex items-center bg-white border border-gray-200 rounded-full px-3 py-1 shadow-sm space-x-2 text-sm">
              <img src="images/firebase-cloud-logo.webp" alt="Firebase" className="w-5 h-5" />
              <span>Firebase</span>
            </div>
            <div className="inline-flex items-center bg-white border border-gray-200 rounded-full px-3 py-1 shadow-sm space-x-2 text-sm">
              <img src="images/ai-integration-icon.webp" alt="AI Integration" className="w-5 h-5" />
              <span>AI Integration</span>
            </div>
            <div className="inline-flex items-center bg-white border border-gray-200 rounded-full px-3 py-1 shadow-sm space-x-2 text-sm">
              <img src="/images/automation-tools-icon.webp" alt="Automation" className="w-5 h-5" />
              <span>Automation</span>
            </div>
          </div>
        </div>
        <div className="flex-[2] mb-10 lg:mb-0">
  <img 
    src="/images/hero-lightlab-development-services_1x.webp" 
    alt="Hero Illustration" 
    className="w-full scale-90 sm:scale-95 md:scale-100 lg:scale-110 xl:scale-120 rounded-xl shadow-xl" 
  />
        </div>
      </div>
    </section>
  );
} 