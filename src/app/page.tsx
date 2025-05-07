import Hero from '@/components/Hero'
import AboutUs from '@/components/AboutUs'
import WhyChoose from '@/components/WhyChoose'
import Services from '@/components/Services'
import Portfolio from '@/components/Portfolio'
import Blog from '@/components/Blog'
import FAQ from '@/components/FAQ'
import ContactForm from '@/components/ContactForm'

export default function Home() {
  return (
    <main className="space-y-16">
      <Hero />
      <AboutUs />
      <WhyChoose />
      <Services />
      <Portfolio />
      <Blog />
      <FAQ />
      <ContactForm />
    </main>
  )
} 