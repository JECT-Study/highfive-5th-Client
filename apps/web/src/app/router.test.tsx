import { cleanup, render, screen } from '@testing-library/react';
import { createMemoryRouter, RouterProvider } from 'react-router';
import { afterEach, describe, expect, it } from 'vitest';
import { appRoutes } from './router';
import { routes } from './routes';

afterEach(cleanup);

describe('app router', () => {
  it('/ 는 /notices 로 보내고 h1 제목을 그린다', async () => {
    const router = createMemoryRouter(appRoutes, { initialEntries: [routes.home] });

    render(<RouterProvider router={router} />);

    await screen.findByRole('heading');
    expect(router.state.location.pathname).toBe(routes.notices);
    expect(screen.getByRole('heading', { level: 1 })).toBeDefined();
    router.dispose();
  });
});
