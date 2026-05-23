import { login, logout } from '../auth'

type Props = {
  user: string | null
  setUser: (user: string | null) => void
}

export default function Header({ user, setUser }: Props) {
  return (
    <header className="header">
      <h1>
        <span className="orange">Cloud</span>Press ☁️
      </h1>

      <nav>
        <a href="#">Artigos</a>
        <a href="#">Vídeos</a>
        <a href="#">Galeria</a>

        {!user ? (
          <a href="#" onClick={login}>Login</a>
        ) : (
          <>
            <span style={{ marginLeft: '1rem' }}>👤 {user}</span>
            <a
              href="#"
              onClick={() => {
                logout()
                setUser(null)
              }}
              style={{ marginLeft: '1rem' }}
            >
              Logout
            </a>
          </>
        )}
      </nav>
    </header>
  )
}
