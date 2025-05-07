import Link from 'next/link';

export default function Header() {
  return (
    <header className="bg-white shadow-sm">
      <div className="container mx-auto px-4 py-6 flex items-center justify-between">
        <Link href="/" className="text-2xl font-bold text-gray-900">
          LightLab
        </Link>
        <nav className="space-x-6">
          <Link href="#about" className="text-gray-600 hover:text-gray-900">About Us</Link>
          <Link href="#services" className="text-gray-600 hover:text-gray-900">Services</Link>
          <Link href="#portfolio" className="text-gray-600 hover:text-gray-900">Portfolio</Link>
          <Link href="#blog" className="text-gray-600 hover:text-gray-900">Blog</Link>
          <Link href="#faq" className="text-gray-600 hover:text-gray-900">FAQ</Link>
          <Link href="#contact" className="text-gray-600 hover:text-gray-900">Contact</Link>
        </nav>
        <Link href="#contact" className="px-4 py-2 bg-indigo-600 text-white rounded-full">
          Book a Consultation
        </Link>
      </div>
    </header>
  );
} 