import { cleanup, fireEvent, render, screen } from '@testing-library/react';
import { afterEach, describe, expect, it } from 'vitest';
import { Checkbox, Radio } from './SelectionControl';

afterEach(cleanup);

describe('SelectionControl', () => {
  it('체크박스는 글자를 눌러도 체크된다', () => {
    render(<Checkbox>만 14세 이상입니다</Checkbox>);

    const checkbox = screen.getByRole('checkbox', {
      name: '만 14세 이상입니다',
    }) as HTMLInputElement;
    fireEvent.click(screen.getByText('만 14세 이상입니다'));

    expect(checkbox.checked).toBe(true);
  });

  it('같은 name의 라디오는 하나만 고른다', () => {
    render(
      <>
        <Radio name="pay">계좌이체</Radio>
        <Radio name="pay">현장 결제</Radio>
      </>,
    );
    const [first, second] = screen.getAllByRole('radio') as HTMLInputElement[];

    fireEvent.click(first);
    fireEvent.click(second);

    expect(first.checked).toBe(false);
    expect(second.checked).toBe(true);
  });
});
