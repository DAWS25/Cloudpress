import './styles.css'
import Header from './components/Header'
import Hero from './components/Hero'
import Articles from './components/Articles'
import Videos from './components/Videos'
import Sponsored from './components/Sponsored'
import LoginBox from './components/LoginBox'
import Footer from './components/Footer'

function App() {
  return (
    <>
      <Header />
      <Hero />

      <main className="container grid">
        <section>
          <Articles />
          <Videos />
        </section>

        <aside>
          <Sponsored />
          <LoginBox />
        </aside>
      </main>

      <Footer />
    </>
  )
}

export default App
