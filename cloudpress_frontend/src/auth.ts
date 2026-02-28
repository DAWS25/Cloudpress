const COGNITO_DOMAIN = import.meta.env.VITE_COGNITO_DOMAIN as string
const CLIENT_ID = import.meta.env.VITE_COGNITO_CLIENT_ID as string
const REDIRECT_URI = import.meta.env.VITE_COGNITO_REDIRECT_URI as string

export function login() {
  const url =
    `${COGNITO_DOMAIN}/login` +
    `?client_id=${CLIENT_ID}` +
    `&response_type=code` +
    `&scope=openid+email+profile` +
    `&redirect_uri=${encodeURIComponent(REDIRECT_URI)}`

  window.location.href = url
}

export function logout() {
  sessionStorage.clear()

  const url =
    `${COGNITO_DOMAIN}/logout` +
    `?client_id=${CLIENT_ID}` +
    `&logout_uri=${encodeURIComponent(REDIRECT_URI)}`

  window.location.href = url
}

export async function exchangeCodeForToken(code: string) {
  const response = await fetch(`${COGNITO_DOMAIN}/oauth2/token`, {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      grant_type: "authorization_code",
      client_id: CLIENT_ID,
      code,
      redirect_uri: REDIRECT_URI,
    }),
  })

  if (!response.ok) {
    throw new Error("Erro ao trocar code por token")
  }

  return response.json()
}

export function getUser() {
  const token = sessionStorage.getItem("id_token")
  if (!token) return null

  const payload = JSON.parse(atob(token.split(".")[1]))
  return payload.email || payload["cognito:username"]
}
