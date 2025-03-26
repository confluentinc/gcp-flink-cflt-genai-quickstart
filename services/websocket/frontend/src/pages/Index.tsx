import { Navbar } from '@/components/Navbar'
import { Button } from '@/components/ui/button'
import { Link } from 'react-router-dom'
import { Heart, Shield, MessageCircle } from 'lucide-react'
import doctor from '@/assets/doctor.png'

const Index = () => {
  return (
    <div className="min-h-screen bg-gradient-to-b from-white to-gray-50">
      <Navbar />
      <main className="container mx-auto px-4 pt-32 pb-16">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8 items-center bg-[url('bg.jpeg')] bg-cover bg-center p-8 rounded-lg">
          <section className="text-center space-y-6 animate-fadeIn">
            <div className="inline-flex items-center bg-primary/10 text-primary border border-primary rounded-full px-4 py-2.5 text-lg font-medium mb-8 mx-auto">
              <span className="relative flex h-2 w-2 mr-2">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-primary opacity-75"></span>
                <span className="relative inline-flex rounded-full h-2 w-2 bg-primary"></span>
              </span>
              New AI Assistant Now Available
            </div>
            <h1 className="text-4xl md:text-6xl font-bold text-secondary tracking-tight">
              <span>Your Health,</span> <span className="text-[#00c1e8]">Our Priority</span>
            </h1>
            <p className="text-xl text-gray-600 max-w-2xl mx-auto">
              Experience healthcare reimagined with our AI-powered platform. Get instant answers to
              your health questions.
            </p>
            <div className="flex flex-wrap gap-4 justify-center">
              <Link to="/assistant">
                <Button
                  size="circle"
                  className="border border-2 border-[#81d5fb] bg-[#23a8e6] hover:bg-[#0FA5E9]/90 text-[#fff] transition-colors shadow-lg shadow-[#23a8e6]/50"
                >
                  <span className="text-lg">
                    Try AI
                    <br />
                    Assistant
                  </span>
                </Button>
              </Link>
            </div>
          </section>

          <section className="animate-fadeIn">
            <div className="overflow-hidden ">
              <img
                src={doctor}
                alt="Healthcare AI Assistant"
                className="w-3/5 h-auto object-cover mx-auto rounded-lg"
              />
            </div>
          </section>
        </div>

        <section className="mt-24 grid md:grid-cols-3 gap-8 bg-[#DCF7FB] p-8 rounded-lg">
          {[
            {
              icon: <Heart className="w-6 h-6 text-white" />,
              title: 'Personalized Care',
              description:
                'Get healthcare tailored to your unique needs with our AI-powered platform.',
            },
            {
              icon: <Shield className="w-6 h-6 text-white" />,
              title: 'Secure & Private',
              description: 'Your health data is protected with enterprise-grade security measures.',
            },
            {
              icon: <MessageCircle className="w-6 h-6 text-white" />,
              title: '24/7 Support',
              description: 'Access our AI health assistant anytime, anywhere for instant support.',
            },
          ].map((feature, index) => (
            <div
              key={index}
              className="p-6 bg-white rounded-lg border border-[#0FA5E9]/20 hover:bg-gray-50 transition-colors animate-fadeIn"
            >
              <div className="w-12 h-12 bg-[#0FA5E9] rounded-lg flex items-center justify-center mb-4">
                {feature.icon}
              </div>
              <h3 className="text-xl font-semibold mb-2 text-[#0FA5E9]">{feature.title}</h3>
              <p className="text-gray-600">{feature.description}</p>
            </div>
          ))}
        </section>
      </main>
    </div>
  )
}

export default Index
