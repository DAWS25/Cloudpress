import { useEffect, useState } from 'react'
import './styles.css'
import Header from './components/Header'
import Hero from './components/Hero'
import Articles from './components/Articles'
import Videos from './components/Videos'
import Sponsored from './components/Sponsored'
import LoginBox from './components/LoginBox'
import UploadBox from './components/UploadBox'
import Footer from './components/Footer'
import { exchangeCodeForToken, getUser } from './auth'

function App() {
  const [user, setUser] = useState<string | null>(getUser())

  useEffect(() => {
    const params = new URLSearchParams(window.location.search)
    const code = params.get("code")

    if (code) {
      exchangeCodeForToken(code)
        .then(tokens => {
          sessionStorage.setItem("id_token", tokens.id_token)
          sessionStorage.setItem("access_token", tokens.access_token)

          setUser(getUser()) // 🔥 força re-render

          window.history.replaceState({}, document.title, "/")
        })
        .catch(console.error)
    }
  }, [])

  return (
    <>
      <Header user={user} setUser={setUser} />
      <Hero />

      <main className="container grid">
        <section>
          <Articles />
          <Videos />
        </section>

        <aside>
          <Sponsored />
          <LoginBox user={user} setUser={setUser} />
          <UploadBox user={user} />
        </aside>
      </main>

      <Footer />
    </>
  )
}

export default App
